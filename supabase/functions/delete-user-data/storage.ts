import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

const foldersForUser = (userId: string) => [
  `avatars/${userId}`,
  `goals/${userId}`,
  `receipts/${userId}`,
];

export async function deleteUserFiles(
  admin: SupabaseClient,
  userId: string,
) {
  const bucket = admin.storage.from("profile");
  for (const folder of foldersForUser(userId)) {
    while (true) {
      const { data, error } = await bucket.list(folder, {
        limit: 100,
        offset: 0,
      });
      if (error) {
        if (error.message.toLowerCase().includes("not found")) break;
        throw error;
      }
      if (!data?.length) break;
      const paths = data.map((file) => `${folder}/${file.name}`);
      const { error: removeError } = await bucket.remove(paths);
      if (removeError) throw removeError;
      if (data.length < 100) break;
    }
  }
}
